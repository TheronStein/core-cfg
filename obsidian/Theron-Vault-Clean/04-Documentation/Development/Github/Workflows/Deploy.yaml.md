```yaml
name: Deploy to Remote Server

on:
  push:
    branches:
      - main  # or any other branch you want to trigger deployments

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Check out repository
        uses: actions/checkout@v2

      - name: Log in to Docker Hub
        run: echo "${{ secrets.DOCKER_PASSWORD }}" | docker login -u "${{ secrets.DOCKER_USERNAME }}" --password-stdin

      - name: Build and push Docker image
        run: |
          docker build -t your-dockerhub-username/your-project-name:latest .
          docker push your-dockerhub-username/your-project-name:latest

      - name: Deploy to Remote Server via SSH
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.REMOTE_HOST }}
          username: ${{ secrets.REMOTE_USER }}
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          envs: DOCKER_IMAGE=your-dockerhub-username/your-project-name:latest
          script: |
            docker pull $DOCKER_IMAGE
            docker stop your-container-name || true
            docker rm your-container-name || true
            docker run -d --name your-container-name -p 8080:8080 $DOCKER_IMAGE

```