kubectl config set-credentials oidc \
      --exec-api-version=client.authentication.k8s.io/v1beta1 \
      --exec-command=kubectl \
      --exec-arg=oidc-login \
      --exec-arg=get-token \
      --exec-arg=--oidc-issuer-url=https://dev-58749656.okta.com/oauth2/aushzoh1hhZLz3coX5d7 \
      --exec-arg=--oidc-client-id=0oahzoh66sy1pZlTL5d7 \
      --exec-arg=--oidc-extra-scope="email offline_access profile openid"
