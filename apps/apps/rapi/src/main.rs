use axum::{Router, routing::get};
use hello_world::HelloRequest;
use hello_world::greeter_client::GreeterClient;

pub mod hello_world {
    tonic::include_proto!("helloworld");
}

fn get_env(key: &str) -> String {
    std::env::var(key).unwrap_or_else(|_| panic!("Set the {key} env variable"))
}

async fn make_grpc_request() -> Result<String, Box<dyn std::error::Error>> {
    let addr = get_env("GRPC_ADDRESS");
    // http://[::1]:50051
    println!("GRPC_ADDRESS={addr}");
    // TODO: don'T always create a new connection!
    let mut client = GreeterClient::connect(addr).await?;

    let request = tonic::Request::new(HelloRequest {
        name: "Tonic".into(),
    });

    let response = client.say_hello(request).await?;
    let msg = response.into_inner().message;

    // println!("RESPONSE={response:?}");
    Ok(msg)
}

async fn handle_route() -> String {
    println!("handling route...");
    let r = make_grpc_request().await.unwrap();
    format!("Hello from {:?}", r)
}

#[tokio::main]
async fn main() {
    // PORT=8000 GRPC_ADDRESS=http://\[::1\]:50051 cr -p rapi

    // build our application with a single route
    let app = Router::new().route("/", get(handle_route));

    // run our app with hyper, listening globally
    let port = get_env("PORT");
    let address = format!("0.0.0.0:{}", port);
    let listener = tokio::net::TcpListener::bind(address).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
