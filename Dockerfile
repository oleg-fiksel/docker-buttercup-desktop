FROM node:11 as build

ARG TAG=v1.12.2
RUN git clone -b ${TAG} https://github.com/buttercup/buttercup-desktop /app
RUN cd /app \
	&& sed -i '/"rpm",/d' "package.json" \
	&& sed -i '/"AppImage",/d' "package.json" \
	&& sed -i '/"snap",/d' "package.json" \
	&& sed -i 's/"deb"/"dir"/' "package.json"
RUN cd /app \
	&& npm install \
	&& npm run build \
	&& npm run package:linux

FROM ubuntu:18.04

RUN apt-get update && apt-get install -y libgtk-3-0 libxss1 libnss3 libasound2
RUN apt-get clean 
RUN useradd -m -u 1000 -s /bin/bash app
COPY --from=build /app/release/linux-unpacked /home/app/bin
RUN chown -R app /home/app/bin
WORKDIR /home/app/bin
USER app
CMD ["./buttercup-desktop"]
