TFSEC_VERSION?=v1.28.1
TFLINT_VERSION?=v0.45.0
TFDOCS_VERSION?=0.17.0

# Run tflint
.PHONY: tflint
tflint:
	docker run --rm -it --entrypoint=/bin/sh --workdir /data -v ${PWD}:/data ghcr.io/terraform-linters/tflint:${TFLINT_VERSION} \
		-c "tflint --init; tflint --recursive"

# Run tfsec
.PHONY: tfsec
tfsec:
	docker run --rm -it --entrypoint=/bin/sh --workdir /data -v ${PWD}:/data aquasec/tfsec-ci:${TFSEC_VERSION} \
		-c "tfsec ." 

# Run tfdocs
.PHONY: tfdocs
tfdocs:
	docker run --rm -it --entrypoint=/bin/sh --workdir /data -v ${PWD}:/data quay.io/terraform-docs/terraform-docs:${TFDOCS_VERSION} \
		-c "terraform-docs markdown ."

.PHONY: pre
pre: tflint tfsec
