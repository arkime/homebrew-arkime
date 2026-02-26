class ArkimeWise < Formula
  desc "Service wrapper for Arkime WISE"
  homepage "https://arkime.com"
  url "https://github.com/arkime/arkime/archive/refs/tags/v6.0.0-rc4.tar.gz"
  sha256 "2aac4c36aaa55a9955dbc6c6d311877b9e93cbc115e4379208056cae9fa7d84f"
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
