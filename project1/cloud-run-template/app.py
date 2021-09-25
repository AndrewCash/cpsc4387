import os
from flask import Flask, render_template, request
from google.cloud import pubsub_v1


app = Flask(__name__, template_folder='templates')


@app.route('/', methods=['GET', 'POST'])
def test_page():
    project = "cpsc-4387-project-1"
    if request.method == 'POST':
        action = request.form['action']
<<<<<<< HEAD
        pubsub_topic = "build_server_or_whatever_you_want"
        publisher = pubsub_v1.PublisherClient()
        topic_path = publisher.topic_path(project, pubsub_topic)
        future = publisher.publish(topic_path, data=b'Some text noone will read', action=action)
=======
        pubsub_topic = "project-1-topic"
        publisher = pubsub_v1.PublisherClient()
        topic_path = publisher.topic_path(project, pubsub_topic)
        future = publisher.publish(topic_path, data=b'I feel vigorous', action=action)
>>>>>>> dev_2
        print(future.result())
    page_template = 'base_template.html'
    return render_template(page_template)


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=int(os.environ.get("PORT", 5000)))
