class ArkimeParliament < Formula
  desc "Service wrapper for Arkime Parliament"
  homepage "https://arkime.com"
  url "https://github.com/arkime/arkime/archive/refs/tags/v6.0.0.tar.gz"
  sha256 "8a9ae7b57ff59554ea4b1d36b4f65039194ee2bde1ef1ba8b617316a8fc56ab1"
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
