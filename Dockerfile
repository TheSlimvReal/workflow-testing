# This docker image can be used to run the application locally.
# To use it only Docker needs to be installed locally
# Run the following commands from the root folder to build, run and kill the application
# >> docker build -f docker/pipeline/Dockerfile -t aam/digital:latest .
# >> docker run -p=80:80 -t aam/digital:latest aam-digital
# >> docker kill aam-digital
FROM node:15.1.0-alpine3.12 as builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --no-progress
RUN $(npm bin)/ng version
ARG RUN_TESTS=false
ARG CHROME_BIN=/usr/bin/chromium-browser
RUN if [ "$RUN_TESTS" = true ] ; then \
    apk --no-cache add chromium ; fi

RUN npm run postinstall
RUN $(npm bin)/ng version

COPY . .
RUN if [ "$RUN_TESTS" = true ] ; then \
    npm run lint &&\
    npm run test-ci ; fi

CMD npm test-ci
RUN $(npm bin)/ng version
RUN $(npm bin)/ng build --prod
CMD ls -a


FROM nginx:1.19.4-alpine
ENV PORT=80
COPY --from=builder /app/dist/ /usr/share/nginx/html
CMD ls /usr/share/nginx/html

