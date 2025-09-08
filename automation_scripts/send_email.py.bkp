import smtplib
import sys
import os
from email.mime.text import MIMEText

def main():
    if len(sys.argv) < 3:
        print("Usage: send_email.py <subject> <body>")
        sys.exit(1)

    subject = sys.argv[1]
    body = sys.argv[2]

    sender = os.getenv("SMTP_USER")  # sender email address
    recipients = os.getenv("SMTP_TO", sender).split(",")  # can send to yourself for test

    smtp_server = os.getenv("SMTP_SERVER", "localhost")
    smtp_port = int(os.getenv("SMTP_PORT", "25"))

    msg = MIMEText(body)
    msg["Subject"] = subject
    msg["From"] = sender
    msg["To"] = ", ".join(recipients)

    try:
        with smtplib.SMTP(smtp_server, smtp_port) as server:
            server.sendmail(sender, recipients, msg.as_string())
        print("Notification email sent successfully.")
    except Exception as e:
        print(f"Failed to send email: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
