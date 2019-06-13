cp -r ./ /docker/app/
cd /docker
docker login -u "$CI_REGISTRY_USER" -p "$CI_JOB_TOKEN" "$CI_REGISTRY"
docker build --tag "${CI_REGISTRY}/${CI_PROJECT_PATH}:${CI_COMMIT_REF_NAME}" -f /docker/sources/Dockerfile ./
docker push "${CI_REGISTRY}/${CI_PROJECT_PATH}:${CI_COMMIT_REF_NAME}"