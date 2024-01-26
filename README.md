# Giter-Auto
docker build -t your_image_name . -d

docker attach $(docker ps -q -l)

# ?
docker run -it your_image_name
docker attach $(docker ps -q -l)

docker logs your_image_name