class ArkimeWise < Formula
  desc "Service wrapper for Arkime WISE"
  homepage "https://arkime.com"
  url "https://github.com/arkime/arkime/archive/refs/tags/v6.1.0.tar.gz"
  sha256 "db2f4ae2b89ba3048fafd82814fb1e1c3343acb4b217cb5e573dc038e474a909"
  license "Apache-2.0"

  depends_on "arkime/arkime/arkime"
  depends_on "node@22"

  def install
    (bin/"arkime-wise-service").write <<~EOS
      #!/bin/bash
      exec "#{Formula["node@22"].opt_bin}/node" "#{Formula["arkime"].opt_prefix}/wiseService/wiseService.js" -c "#{etc}/arkime/wise.ini" "$@"
    EOS
  end

  service do
    run [Formula["node@22"].opt_bin/"node", Formula["arkime"].opt_prefix/"wiseService/wiseService.js", "-c", etc/"arkime/wise.ini"]
    keep_alive true
    log_path var/"log/arkime/wise.log"
    error_log_path var/"log/arkime/wise.error.log"
    working_dir Formula["arkime"].opt_prefix/"wiseService"
  end

  test do
    assert_predicate bin/"arkime-wise-service", :exist?
  end
end
