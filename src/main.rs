use log::{info, warn, error};
use std::process::Command;
use tokio::time::{sleep, Duration};

#[tokio::main]
async fn main() {
    // Initialize logger
    env_logger::init();
    
    info!("Pi Auto-Reboot service started");
    info!("Monitoring internet connectivity by pinging google.com every minute");
    info!("System will reboot after 3 consecutive ping failures");
    
    let mut consecutive_failures = 0;
    const MAX_FAILURES: u32 = 3;
    const PING_INTERVAL: Duration = Duration::from_secs(60); // 1 minute
    
    loop {
        match ping_google().await {
            Ok(_) => {
                if consecutive_failures > 0 {
                    info!("Internet connection restored after {} failures", consecutive_failures);
                }
                consecutive_failures = 0;
                info!("Ping to google.com successful");
            }
            Err(e) => {
                consecutive_failures += 1;
                warn!("Ping failed ({}/{}): {}", consecutive_failures, MAX_FAILURES, e);
                
                if consecutive_failures >= MAX_FAILURES {
                    error!("Internet connection failed {} times consecutively. Initiating system reboot...", MAX_FAILURES);
                    reboot_system().await;
                    break;
                }
            }
        }
        
        sleep(PING_INTERVAL).await;
    }
}

async fn ping_google() -> Result<(), String> {
    let output = Command::new("ping")
        .arg("-c")
        .arg("1")
        .arg("-W")
        .arg("5000") // 5 second timeout
        .arg("google.com")
        .output()
        .map_err(|e| format!("Failed to execute ping command: {}", e))?;
    
    if output.status.success() {
        Ok(())
    } else {
        let stderr = String::from_utf8_lossy(&output.stderr);
        Err(format!("Ping command failed: {}", stderr))
    }
}

async fn reboot_system() {
    info!("Attempting to reboot the system...");
    
    let result = Command::new("sudo")
        .arg("shutdown")
        .arg("-r")
        .arg("now")
        .output();
    
    match result {
        Ok(output) => {
            if output.status.success() {
                info!("Reboot command executed successfully");
            } else {
                let stderr = String::from_utf8_lossy(&output.stderr);
                error!("Reboot command failed: {}", stderr);
            }
        }
        Err(e) => {
            error!("Failed to execute reboot command: {}", e);
        }
    }
}
