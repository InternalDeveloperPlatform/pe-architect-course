## Policy as Code Setup

Should already be done from foudnation model. But to review, these should be working below

First steps

1. Connect to K8s cluster
2. Install OPA Gatekeeper (see foundation module)

### Verify gatekeeper install worked.

Deploy a simple constraint template
`k apply -f ../foundation/simple-constraint-template.yaml`

``` yaml
apiVersion: templates.gatekeeper.sh/v1
kind: ConstraintTemplate
metadata:
  name: k8srequiredlabels
spec:
  crd:
    spec:
      names:
        kind: K8sRequiredLabels
      validation:
        # Schema for the `parameters` field
        openAPIV3Schema:
          type: object
          properties:
            labels:
              type: array
              items:
                type: string
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8srequiredlabels

        violation[{"msg": msg, "details": {"missing_labels": missing}}] {
          provided := {label | input.review.object.metadata.labels[label]}
          required := {label | label := input.parameters.labels[_]}
          missing := required - provided
          count(missing) > 0
          msg := sprintf("you must provide labels: %v", [missing])
        }
```

`k apply -f ../foundation/simple-constraint.yaml`

``` yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredLabels
metadata:
  name: ns-must-have-gk
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Namespace"]
  parameters:
    labels: ["admission"]
```

Now try to deploy a namespace
`k create ns will-be-denied`

This should be accepted.
`k apply -f ../foundation/simple-ns-with-label.yaml`


## CVE Module

See ./cve/README.md

## Quality Module

See ./quality/README.md
