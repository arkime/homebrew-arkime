class ArkimeCont3xt < Formula
  desc "Service wrapper for Arkime Cont3xt"
  homepage "https://arkime.com"
  url "https://github.com/arkime/arkime/archive/refs/tags/v6.3.0.tar.gz"
  sha256 "5f6dfb3723db8725105395a49d9bb5133aefbe1b6165460b07a34ca975036790"
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
