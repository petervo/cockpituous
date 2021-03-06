all:
	@echo "usage: make containers" >&2
	@echo "       make release-shell" >&2
	@echo "       make release-container" >&2
	@echo "       make release-install" >&2

base-container:
	docker build -t cockpit/infra-base base

containers: release-container verify-container
	@true

release-shell:
	docker run -ti --rm -v /home/cockpit:/home/user:rw \
		--volume=/home/cockpit/release:/build:rw \
		--volume=$(CURDIR)/release:/usr/local/bin \
		--entrypoint=/bin/bash cockpit/infra-release

release-container:
	docker build -t cockpit/infra-release release

release-install: release-container
	cp release/cockpit-release.service /etc/systemd/system/
	systemctl daemon-reload
	systemctl enable cockpit-release

verify-shell:
	docker run -ti --rm \
		--volume /home/cockpit:/home/user \
		--volume $(CURDIR)/verify:/usr/local/bin \
		--volume=/opt/verify:/build:rw \
		--net=host --pid=host --privileged --entrypoint=/bin/bash \
        cockpit/infra-verify -i

verify-container:
	docker build -t cockpit/infra-verify verify

verify-install: verify-container
	cp verify/cockpit-verify.service /etc/systemd/system/
	systemctl daemon-reload
	systemctl enable cockpit-verify
