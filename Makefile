GO   := go

pkgs  = $(shell GOFLAGS=-mod=vendor $(GO) list ./... | grep -vE -e /vendor/ -e /pkg/swagger/)
pkgDirs = $(shell GOFLAGS=-mod=vendor $(GO) list -f {{.Dir}} ./... | grep -vE -e /vendor/ -e /pkg/swagger/)

.PHONY: build build.http-go-server

build:
	$(GO) build -o bin/http-server internal/main.go

.PHONY: build build.clean

clean:
	rm -f bin/*

.PHONY: swagger.validate

swagger.validate:
	swagger validate pkg/swagger/swagger.yml

.PHONY: swagger.doc

swagger.doc:
	docker run -i yousan/swagger-yaml-to-html < pkg/swagger/swagger.yml > doc/index.html

.PHONY:generate

generate:
	@echo "==> generating go code"
	GOFLAGS=-mod=vendor $(GO) generate $(pkgs)

format:
	@echo "==> formatting code"
	@$(GO) fmt $(pkgs)
	@echo "==> clean imports"
	@goimports -w $(pkgDirs)
	@echo "==> simplify code"
	@gofmt -s -w $(pkgDirs)

# https://ops.tips/blog/a-swagger-golang-hello-world/
gen: swagger.validate
	swagger generate server --quiet --target pkg/swagger/server --name hello-api --spec pkg/swagger/swagger.yml --exclude-main
