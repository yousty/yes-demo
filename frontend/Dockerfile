FROM public.ecr.aws/docker/library/node:24-bookworm-slim

ENV NODE_ENV=development

WORKDIR /app

# Install deps first for caching.
COPY package.json package-lock.json* ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "run", "dev"]
