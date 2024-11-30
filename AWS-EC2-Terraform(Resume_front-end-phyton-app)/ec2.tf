resource "aws_instance" "server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = "demo"
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id              = aws_subnet.sub1.id

  connection {
    type        = "ssh"
    user        = "ubuntu"  # Replace with the appropriate username for your EC2 instance
    private_key = file("~/Downloads/demo.pem")  # Replace with the path to your private key
    host        = self.public_ip
  }

  # File provisioner to copy a file from local to the remote EC2 instance
  provisioner "file" {
    source      = "./Flask_Application"  # The source folder on your local machine
    destination = "/home/ubuntu/Flask_Application"  # Destination on the remote EC2 instance
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",  # Update package lists (for ubuntu)
      "sudo apt install python3 python3-pip python3-venv -y",  # Install required packages
      "cd /home/ubuntu/Flask_Application",  # Change to the Flask application directory
      "python3 -m venv venv",  # Create a virtual environment
      "bash -c 'source venv/bin/activate && pip install flask'",  # Activate venv and install Flask
      "bash -c 'source venv/bin/activate && python -m flask --version'",  # Verify Flask installation
      "bash -c 'source venv/bin/activate && python /home/ubuntu/Flask_Application/app.py'"  # Run the app inside the virtual environment
    ]
  }
}
