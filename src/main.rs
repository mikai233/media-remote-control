use actix_web::{App, HttpResponse, HttpServer, get};
use serde::{Deserialize};
use simulate::Key;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    println!("Server start at:[0.0.0.0:7723]");
    HttpServer::new(|| {
        App::new()
            .service(media)
    })
        .bind(("0.0.0.0", 7723))?
        .run()
        .await
}

#[derive(Debug, Deserialize)]
pub struct Req {
    cmd: Cmd,
}

#[derive(Debug, Deserialize)]
enum Cmd {
    PlayPause,
    Stop,
    Next,
    Previous,
    VolumeUp,
    VolumeDown,
    VolumeMute,
}

#[get("/media")]
async fn media(info: actix_web::web::Query<Req>) -> actix_web::Result<HttpResponse> {
    let _ = match info.cmd {
        Cmd::PlayPause => simulate::press(Key::MediaPlayPause),
        Cmd::Stop => simulate::press(Key::MediaStop),
        Cmd::Next => simulate::press(Key::MediaNextTrack),
        Cmd::Previous => simulate::press(Key::MediaPreviousTrack),
        Cmd::VolumeUp => simulate::press(Key::VolumeUp),
        Cmd::VolumeDown => simulate::press(Key::VolumeDown),
        Cmd::VolumeMute => simulate::press(Key::VolumeMute),
    };
    println!("{:?}", info.0);
    let mut resp = HttpResponse::Ok();
    Ok(resp.finish())
}