class ArkimeCapture < Formula
  desc "Service wrapper for Arkime packet capture"
  homepage "https://arkime.com"
  url "https://github.com/arkime/arkime/archive/refs/tags/v6.1.0.tar.gz"
  sha256 "db2f4ae2b89ba3048fafd82814fb1e1c3343acb4b217cb5e573dc038e474a909"
  license "Apache-2.0"

  depends_on "arkime/arkime/arkime"

  def install
    (bin/"arkime-capture-service").write <<~EOS
      #!/bin/bash
      exec "#{Formula["arkime"].opt_bin}/capture" -c "#{etc}/arkime/config.ini" "$@"
    EOS
  end

  service do
    run [Formula["arkime"].opt_bin/"capture", "-c", etc/"arkime/config.ini"]
    keep_alive true
    require_root true
    log_path var/"log/arkime/capture.log"
    error_log_path var/"log/arkime/capture.error.log"
    working_dir var/"arkime"
  end

  test do
    assert_predicate bin/"arkime-capture-service", :exist?
  end
end
