class ArkimeCont3xt < Formula
  desc "Service wrapper for Arkime Cont3xt"
  homepage "https://arkime.com"
  url "https://github.com/arkime/arkime/archive/refs/tags/v6.0.0.tar.gz"
  sha256 "8a9ae7b57ff59554ea4b1d36b4f65039194ee2bde1ef1ba8b617316a8fc56ab1"
  license "Apache-2.0"

  depends_on "arkime/arkime/arkime"
  depends_on "node@22"

  def install
    (bin/"arkime-cont3xt-service").write <<~EOS
      #!/bin/bash
      exec "#{Formula["node@22"].opt_bin}/node" "#{Formula["arkime"].opt_prefix}/cont3xt/cont3xt.js" -c "#{etc}/arkime/cont3xt.ini" "$@"
    EOS
  end

  service do
    run [Formula["node@22"].opt_bin/"node", Formula["arkime"].opt_prefix/"cont3xt/cont3xt.js", "-c", etc/"arkime/cont3xt.ini"]
    keep_alive true
    log_path var/"log/arkime/cont3xt.log"
    error_log_path var/"log/arkime/cont3xt.error.log"
    working_dir Formula["arkime"].opt_prefix/"cont3xt"
  end

  test do
    assert_predicate bin/"arkime-cont3xt-service", :exist?
  end
end
