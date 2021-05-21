extern crate wapc_guest as guest;
extern crate wasmcloud_actor_http_server as httpserver;

use guest::prelude::*;

#[wasmcloud_actor_core::init]
fn init() {
    httpserver::Handlers::register_handle_request(test_body);
}

fn test_body(msg: httpserver::Request) -> HandlerResult<httpserver::Response> {
    let nums: Vec<&str> = msg.query_string.split(",").collect();
    let mut ret: String = String::from("Welcome to wasmcloud calculator");

    loop {
        match msg.path.as_str() {
            "/add" => {
                let sum = nums[0].parse::<i32>().unwrap() + nums[1].parse::<i32>().unwrap();
                ret = format!("add: {} + {} = {}", nums[0], nums[1], sum);
                break;
            }
            "/sub" => {
                let sub = nums[0].parse::<i32>().unwrap() - nums[1].parse::<i32>().unwrap();
                ret = format!("subtract: {} - {} = {}", nums[0], nums[1], sub);
                break;
            }
            // TODO: add multiplication
            "/div" => {
                if nums[1] == "0" {
                    ret = String::from("Can not divide by zero!");
                    break;
                }
                let div = nums[0].parse::<i32>().unwrap() / nums[1].parse::<i32>().unwrap();
                ret = format!("divide: {} / {} = {}", nums[0], nums[1], div);
                break;
            }
            _ => {
                break;
            }
        }
    }
    return Ok(httpserver::Response {
        status_code: 200,
        status: "OK".to_string(),
        header: msg.header,
        body: ret.as_bytes().to_vec(),
    });
}
