# Build Stage
FROM node:14 AS Build_image
WORKDIR /app
COPY package*.json /app/
RUN npm install
COPY . .
RUN npm run build

# Final Stage
FROM nginx:latest
RUN rm -rf /usr/share/nginx/html/
COPY --from=Build_image /app/build/* /usr/share/nginx/html/
EXPOSE 80
