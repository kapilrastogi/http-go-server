package main

import (
	"github.com/go-openapi/loads"
	"github.com/go-openapi/runtime/middleware"
	"krastogi/http-go-server/pkg/swagger/server/restapi"
	"krastogi/http-go-server/pkg/swagger/server/restapi/operations"
	"log"
)

func main() {
	swaggerSpec, err := loads.Analyzed(restapi.SwaggerJSON, "")

	if err != nil {
		log.Fatalln(err)
	}

	api := operations.NewHelloAPI(swaggerSpec)
	server := restapi.NewServer(api)

	defer func() {
		if err := server.Shutdown(); err != nil {
			// error handle
			log.Fatalln(err)
		}
	}()

	server.Port = 8080

	api.CheckHealthHandler = operations.CheckHealthHandlerFunc(Health)
	api.GetHelloUserHandler = operations.GetHelloUserHandlerFunc(GetHelloUser)

	// Start server which listening
	if err := server.Serve(); err != nil {
		log.Fatalln(err)
	}
}

//Health route returns OK
func Health(operations.CheckHealthParams) middleware.Responder {
	return operations.NewCheckHealthOK().WithPayload("OK")
}

//GetHelloUser returns Hello + your name
func GetHelloUser(user operations.GetHelloUserParams) middleware.Responder {
	return operations.NewGetHelloUserOK().WithPayload("Hello " + user.User + "!")
}
