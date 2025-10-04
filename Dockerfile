# https://hub.docker.com/_/node/tags
######### BUILDER #############
# define imagem a ser utilizada pelo builder 
FROM node:lts AS builder 

# define path default para arquivo 
WORKDIR /usr/src/app

# copia arquivos locais para dentro da imagem 
COPY  ./mini-curso-devops/ ./

# instalar dependencias(garante versão com o CI)
RUN npm ci  

# Build o projeto gerando uma saida 
RUN npm run build


######### RUNTIME #############
# define uma imagem para o runtime 
FROM nginx:stable-alpine AS runtime 

# Deleta o arquivo default do Nginx para adicionar um novo 
RUN rm -f /etc/nginx/conf.d/default.conf

# Envia um arquivo customizado para o Container 
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Envia o arquivo buildado no estagio anterior
COPY --from=builder /usr/src/app/dist/ /usr/share/nginx/html/

# Expose a porta do NGINX, ou seja externaliza o nginx da Imagem 
EXPOSE 80

# Health Check para verificar se a aplicaçao continua online 
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -fsS http://localhost/ > /dev/null || exit 1
  
# Usa o processo do Nginx como daemon para o container se manter online 
CMD ["nginx", "-g", "daemon off;"]