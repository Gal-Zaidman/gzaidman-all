# Create a test pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: test-pod
  name: test-pod
spec:
  containers:
  - args:
    - sleep
    - 360m
    image: quay.io/openshift/origin-tests:4.4
    name: test-pod
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
  command:
  - /bin/sh
  - c
  - |
    #!/bin/sh
    while true; do
      sleep 20m & wait $!
    done
status: {}
```