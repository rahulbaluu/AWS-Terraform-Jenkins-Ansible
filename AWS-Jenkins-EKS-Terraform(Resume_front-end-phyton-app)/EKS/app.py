from flask import Flask, render_template, request

app = Flask(__name__)

class JobApplication:
    def __init__(self, name, email, phone, position, resume):
        self.name = name
        self.email = email
        self.phone = phone
        self.position = position
        self.resume = resume

    def display_application(self):
        return f"Name: {self.name}<br>Email: {self.email}<br>Phone: {self.phone}<br>Position Applied: {self.position}<br>Resume: {self.resume}"

@app.route("/", methods=["GET", "POST"])
def home():
    if request.method == "POST":
        # Collect user input from the form
        name = request.form["name"]
        email = request.form["email"]
        phone = request.form["phone"]
        position = request.form["position"]
        resume = request.form["resume"]

        # Create an instance of JobApplication
        application = JobApplication(name, email, phone, position, resume)

        # Display the details before submission
        application_details = application.display_application()

        # Simulate submission
        application_status = "Your application has been successfully submitted!"

        return render_template("application_submitted.html", application_details=application_details, application_status=application_status)
    
    # Display the form if the request is GET
    return render_template("application_form.html")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
