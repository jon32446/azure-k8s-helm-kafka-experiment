from locust import HttpUser, task, between


class TimeHammerUser(HttpUser):
    wait_time = between(1, 7)

    @task
    def view_root(self):
        self.client.get("/")

    @task(5)
    def view_time(self):
        self.client.get("/time")
