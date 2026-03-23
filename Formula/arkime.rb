class Arkime < Formula
  desc "Full packet capture, indexing, and database system"
  homepage "https://arkime.com"
  url "https://github.com/arkime/arkime/archive/refs/tags/v6.1.0.tar.gz"
  sha256 "db2f4ae2b89ba3048fafd82814fb1e1c3343acb4b217cb5e573dc038e474a909"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  keg_only "arkime is not intended to be linked into the Homebrew prefix"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "node@22" => :build
  depends_on "pkg-config" => :build
  depends_on "wget" => :build

  depends_on "curl"
  depends_on "geoipupdate"
  depends_on "glib"
  depends_on "libmagic"
  depends_on "libmaxminddb"
  depends_on "libpcap"
  depends_on "librdkafka"
  depends_on "libyaml"
  depends_on "lua"
  depends_on :macos
  depends_on "nghttp2"
  depends_on "openssl@3"
  depends_on "ossp-uuid"
  depends_on "yara"
  depends_on "zstd"

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

    # Copy sample configs to /opt/homebrew/etc/arkime/ (survives upgrades)
    first_install = !(etc/"arkime/config.ini").exist?
    %w[config.ini.sample wise.ini.sample cont3xt.ini.sample parliament.ini.sample].each do |sample|
      src = prefix/"etc"/sample
      dest = etc/"arkime"/sample.delete_suffix(".sample")
      next if !src.exist? || dest.exist?

      cp src, dest
      inreplace dest, "ARKIME_INSTALL_DIR/etc", etc/"arkime", audit_result: false
      inreplace dest, "ARKIME_INSTALL_DIR/logs", var/"log/arkime", audit_result: false
      inreplace dest, "ARKIME_INSTALL_DIR/raw", var/"arkime/raw", audit_result: false
      inreplace dest, "ARKIME_INSTALL_DIR/cont3xt-cache", var/"arkime/cont3xt-cache", audit_result: false
      inreplace dest, "ARKIME_INSTALL_DIR/bin", prefix/"bin", audit_result: false
      inreplace dest, "ARKIME_INSTALL_DIR/parsers", prefix/"parsers", audit_result: false
      inreplace dest, "ARKIME_INSTALL_DIR/plugins", prefix/"plugins", audit_result: false
      inreplace dest, "ARKIME_ELASTICSEARCH", "http://localhost:9200", audit_result: false
      inreplace dest, /^#geoLite2Country=.*/, "geoLite2Country=#{var}/GeoIP/GeoLite2-City.mmdb", audit_result: false
      inreplace dest, /^#geoLite2ASN=.*/, "geoLite2ASN=#{var}/GeoIP/GeoLite2-ASN.mmdb", audit_result: false
    end

    # Fix config path in arkime_add_user.sh
    add_user_script = bin/"arkime_add_user.sh"
    inreplace add_user_script, %r{/opt/homebrew/Cellar/arkime/[^/]+/etc/}, "#{etc}/arkime/" if add_user_script.exist?

    # Fix DEST_DIR in arkime_update_geo.sh to point to etc/arkime
    geo_script = bin/"arkime_update_geo.sh"
    if geo_script.exist?
      inreplace geo_script, /DEST_DIR=.*/, "DEST_DIR=\"#{etc}/arkime\""
      inreplace geo_script, /geoipupdate/, "/opt/homebrew/bin/geoipupdate"
    end

    system geo_script

    if first_install
      ohai "To add your first admin user, run:"
      ohai "  #{opt_bin}/arkime_add_user.sh admin admin admin --admin"
      opoo "You MUST update ARKIME_INTERFACE and ARKIME_PASSWORD in #{etc}/arkime/config.ini before using Arkime."
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/capture --version", 1)
  end
end
