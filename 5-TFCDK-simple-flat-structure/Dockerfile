FROM hashicorp/jsii-terraform
WORKDIR /
COPY package*.json ./
RUN npm install
RUN npm install -g cdktf-cli
COPY . .