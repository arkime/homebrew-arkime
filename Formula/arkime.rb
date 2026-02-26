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
  depends_on "wget" => :build

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

  keg_only "arkime is not intended to be linked into the Homebrew prefix"

  def install
    system "autoreconf", "--verbose", "--install", "--force"

    ENV["ARKIME_BUILD_FULL_VERSION"] = "v#{version}"
    ENV["ARKIME_BUILD_DATE"] = Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S%:z")

    glib2_cflags = `pkg-config --cflags gio-2.0 gobject-2.0 gthread-2.0 glib-2.0 gmodule-2.0`.chomp
    glib2_libs = `pkg-config --libs gio-2.0 gobject-2.0 gthread-2.0 glib-2.0 gmodule-2.0`.chomp
    lua_cflags = `pkg-config --cflags lua`.chomp
    lua_libs = `pkg-config --libs lua`.chomp

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
    args << "GLIB2_CFLAGS=#{glib2_cflags}"
    args << "GLIB2_LIBS=#{glib2_libs}"
    args << "LUA_CFLAGS=#{lua_cflags}"
    args << "LUA_LIBS=#{lua_libs}"
    args << "KAFKA_CFLAGS=-I#{Formula["librdkafka"].opt_include}/librdkafka"
    args << "KAFKA_LIBS=-L#{Formula["librdkafka"].opt_lib} -lrdkafka"

    system "./configure", *args
    system "make"
    system "make", "install"
  end

  def post_install
    (etc/"arkime").mkpath
    (var/"arkime/raw").mkpath
    (var/"log/arkime").mkpath
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/capture --version", 1)
  end
end
