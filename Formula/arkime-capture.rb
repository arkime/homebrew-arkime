class ArkimeCapture < Formula
  desc "Service wrapper for Arkime packet capture"
  homepage "https://arkime.com"
  url "https://github.com/arkime/arkime/archive/refs/tags/v6.0.0.tar.gz"
  sha256 "8a9ae7b57ff59554ea4b1d36b4f65039194ee2bde1ef1ba8b617316a8fc56ab1"
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
