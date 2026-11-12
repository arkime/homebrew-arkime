class ArkimeCapture < Formula
  desc "Service wrapper for Arkime packet capture"
  homepage "https://arkime.com"
  url "https://github.com/arkime/arkime/archive/refs/tags/v6.9.2.tar.gz"
  sha256 "c75aff52d67525b5d265c740ae0c6360423fe0facaba5a54e0fdcaef853f406d"
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
