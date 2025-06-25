# CICD-P2 - API REST com Pipeline CI/CD

Este projeto implementa uma API REST completa com pipeline CI/CD automatizado para a disciplina de CI/CD da FATEC.

## Funcionalidades

- ✅ **API REST** com operações CRUD
- ✅ **Documentação Swagger** automática
- ✅ **Logging completo** de todas as requisições
- ✅ **Integração com BetterStack** para logs em produção
- ✅ **Pipeline CI/CD** automatizado
- ✅ **Containerização** com Docker
- ✅ **Deploy automatizado** no Render
- ✅ **Gitflow** e padronização de commits

## Pré-requisitos

- Node.js 18+
- Docker e Docker Compose
- MySQL (para desenvolvimento local)
- Conta no GitHub (para CI/CD)
- Conta no Docker Hub
- Conta no Render
- Conta no BetterStack (Logtail)

## 🐳 Docker

### Build manual
```bash
docker build -t cicd-api .
docker run -p 3000:3000 cicd-api
```

### Comandos úteis
```bash
# Ver logs dos containers
docker-compose logs -f

# Parar todos os containers
docker-compose down

# Rebuild da aplicação
docker-compose up --build api
```

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para detalhes.

## 👨‍💻 Autor

**Victor Favretto**
- GitHub: [@victorvf](https://github.com/victorvf)
- Email: victor@email.com

---

> Este projeto foi desenvolvido para a disciplina de CI/CD da FATEC como demonstração prática de DevOps e automação.
