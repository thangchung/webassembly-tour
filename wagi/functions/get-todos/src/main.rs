use serde::Serialize;

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct Todo {
    id: i32,
    name: String,
    is_completed: bool,
}
fn main() {
    println!("Content-Type: text/plain\n");

    let todos = vec![
        Todo {
            id: 1,
            name: String::from("todo 1"),
            is_completed: false,
        },
        Todo {
            id: 2,
            name: String::from("todo 2"),
            is_completed: true,
        },
    ];

    println!("{}", serde_json::to_string_pretty(&todos).unwrap());
}
