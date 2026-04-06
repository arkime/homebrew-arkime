class ArkimeViewer < Formula
  desc "Service wrapper for Arkime Viewer"
  homepage "https://arkime.com"
  url "https://github.com/arkime/arkime/archive/refs/tags/v6.1.1.tar.gz"
  sha256 "5350fbe9810d02ca082dff0e0be553e83d2a85500c9aaf963b45a9e025d33a5c"
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
