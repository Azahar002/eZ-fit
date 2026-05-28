import os
from flask import Flask, render_template, jsonify

app = Flask(__name__)


# ------------------------------------------------------------------ #
# Routes                                                              #
# ------------------------------------------------------------------ #

@app.route("/")
def landing():
    return render_template("landing.html")


@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200


@app.route("/register", methods=["GET", "POST"])
def register():
    # TODO: Implement real registration logic in Step 3
    return render_template("register.html")


@app.route("/login", methods=["GET", "POST"])
def login():
    # TODO: Implement real authentication in Step 3
    return render_template("login.html")


# ------------------------------------------------------------------ #
# Placeholder routes — students will implement these                  #
# ------------------------------------------------------------------ #

@app.route("/logout")
def logout():
    return "Logout — coming in Step 3"


@app.route("/profile")
def profile():
    return "Profile page — coming in Step 4"


@app.route("/workouts/add")
def add_workout():
    return "Add workout — coming in Step 7"


@app.route("/workouts/<int:id>/edit")
def edit_workout(id):
    return "Edit workout — coming in Step 8"


@app.route("/workouts/<int:id>/delete")
def delete_workout(id):
    return "Delete workout — coming in Step 9"


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=True)
