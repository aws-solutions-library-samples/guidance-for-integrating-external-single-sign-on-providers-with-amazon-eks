# provide actual values for OIDC issuer URL and Client ID
kubectl config set-credentials oidc \
      --exec-api-version=client.authentication.k8s.io/v1beta1 \
      --exec-command=kubectl \
      --exec-arg=oidc-login \
      --exec-arg=get-token \
      --exec-arg=--oidc-issuer-url=https://dev-XXXXXX.okta.com/oauth2/XXXXXXXXXXXXXXXXXX \
      --exec-arg=--oidc-client-id=XXXXXXXXXXXXXXXXXX \
      --exec-arg=--oidc-extra-scope="email offline_access profile openid"
