class Arkime < Formula
  desc "Full packet capture, indexing, and database system"
  homepage "https://arkime.com"
  url "https://github.com/arkime/arkime/archive/refs/tags/v6.0.0-rc4.tar.gz"
  sha256 "2aac4c36aaa55a9955dbc6c6d311877b9e93cbc115e4379208056cae9fa7d84f"
  license "Apache-2.0"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "pkg-config" => :build
  depends_on "node@22" => :build

  depends_on "curl"
  depends_on "glib"
  depends_on "libmaxminddb"
  depends_on "libpcap"
  depends_on "librdkafka"
  depends_on "libmagic"
  depends_on "lua"
  depends_on :macos
  depends_on "nghttp2"
  depends_on "openssl@3"
  depends_on "yara"
  depends_on "zstd"

  def install
    system "autoreconf", "--verbose", "--install", "--force"

    glib = Formula["glib"]
    lua = Formula["lua"]

    ENV.append "GLIB2_CFLAGS", `pkg-config --cflags glib-2.0`.chomp
    ENV.append "GLIB2_LIBS", `pkg-config --libs glib-2.0`.chomp
    ENV.append "LUA_CFLAGS", `pkg-config --cflags lua`.chomp
    ENV.append "LUA_LIBS", `pkg-config --libs lua`.chomp

    args = %W[
      --prefix=#{prefix}
      --with-libpcap=#{Formula["libpcap"].opt_prefix}
      --with-maxminddb=#{Formula["libmaxminddb"].opt_prefix}
      --with-yara=#{Formula["yara"].opt_prefix}
      --with-curl=yes
      --with-nghttp2=yes
      --with-zstd=yes
      --with-glib2=no
      --with-lua=no
      --with-pfring=no
      --with-kafka=no
      --without-python
    ]

    ENV.append "KAFKA_CFLAGS", "-I#{Formula["librdkafka"].opt_include}"
    ENV.append "KAFKA_LIBS", "-L#{Formula["librdkafka"].opt_lib} -lrdkafka"

    system "./configure", *args
    system "make"
    system "make", "install"

    # Install Node.js services
    %w[viewer wiseService cont3xt parliament].each do |svc|
      next unless (buildpath/svc).exist?

      cp_r buildpath/svc, prefix/svc
      cd prefix/svc do
        system "npm", "ci", "--production", "--ignore-scripts" if (prefix/svc/"package.json").exist?
      end
    end
  end

  def post_install
    (etc/"arkime").mkpath
    (var/"arkime/raw").mkpath
    (var/"log/arkime").mkpath
  end

  service do
    run [opt_bin/"capture", "-c", etc/"arkime/config.ini"]
    keep_alive true
    log_path var/"log/arkime/capture.log"
    error_log_path var/"log/arkime/capture.error.log"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/capture --version", 1)
  end
end
