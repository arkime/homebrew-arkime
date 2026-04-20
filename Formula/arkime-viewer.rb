class ArkimeViewer < Formula
  desc "Service wrapper for Arkime Viewer"
  homepage "https://arkime.com"
  url "https://github.com/arkime/arkime/archive/refs/tags/v6.2.0.tar.gz"
  sha256 "044ee248230550ed4a6500ba6496e7a61a3b0b78e3fe63dfaf39fb508a666ad3"
  license "Apache-2.0"

  depends_on "arkime/arkime/arkime"
  depends_on "node@22"

  def install
    (bin/"arkime-viewer-service").write <<~EOS
      #!/bin/bash
      exec "#{Formula["node@22"].opt_bin}/node" "#{Formula["arkime"].opt_prefix}/viewer/viewer.js" -c "#{etc}/arkime/config.ini" "$@"
    EOS
  end

  service do
    run [Formula["node@22"].opt_bin/"node", Formula["arkime"].opt_prefix/"viewer/viewer.js", "-c", etc/"arkime/config.ini"]
    keep_alive true
    log_path var/"log/arkime/viewer.log"
    error_log_path var/"log/arkime/viewer.error.log"
    working_dir Formula["arkime"].opt_prefix/"viewer"
  end

  test do
    assert_predicate bin/"arkime-viewer-service", :exist?
  end
end
