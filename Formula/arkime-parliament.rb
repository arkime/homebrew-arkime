class ArkimeParliament < Formula
  desc "Service wrapper for Arkime Parliament"
  homepage "https://arkime.com"
  url "https://github.com/arkime/arkime/archive/refs/tags/v6.6.0.tar.gz"
  sha256 "fd6e579f45d4f774a4e214c7518453500b47aa9826399c0f1bd8cc73bb3c5dfa"
  license "Apache-2.0"

  depends_on "arkime/arkime/arkime"
  depends_on "node@22"

  def install
    (bin/"arkime-parliament-service").write <<~EOS
      #!/bin/bash
      exec "#{Formula["node@22"].opt_bin}/node" "#{Formula["arkime"].opt_prefix}/parliament/parliament.js" -c "#{etc}/arkime/parliament.ini" "$@"
    EOS
  end

  service do
    run [Formula["node@22"].opt_bin/"node", Formula["arkime"].opt_prefix/"parliament/parliament.js", "-c", etc/"arkime/parliament.ini"]
    keep_alive true
    log_path var/"log/arkime/parliament.log"
    error_log_path var/"log/arkime/parliament.error.log"
    working_dir Formula["arkime"].opt_prefix/"parliament"
  end

  test do
    assert_predicate bin/"arkime-parliament-service", :exist?
  end
end
