import { NestFactory } from '@nestjs/core';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module.js';
import { Logger } from '@nestjs/common';
import { configureApp } from './app.setup.js';
import { readFileSync } from 'node:fs';
import { apiReference } from '@scalar/nestjs-api-reference';

const { version, name, description } = JSON.parse(
  readFileSync(new URL('../package.json', import.meta.url), 'utf8'),
);

const logger = new Logger('Bootstrap');
async function bootstrap() {
  try {
    const app = await NestFactory.create(AppModule, {
      logger: ['error', 'warn', 'log'],
    });

    configureApp(app);

    // Configuração do Swagger
    const config = new DocumentBuilder()
      .setTitle(name)
      .setDescription(description)
      .setVersion(version)
      .addBearerAuth()
      .build();
    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('docs', app, document);

    app.use(
      '/reference',
      apiReference({
        spec: {
          content: document,
        },
      }),
    );

    const port = process.env.PORT || 9000;
    await app.listen(port);
    logger.log(`Servidor iniciado na porta ${port}`);
  } catch (error) {
    logger.error(`Erro ao iniciar a aplicação: ${error.message}`);
    process.exit(1);
  }
}
bootstrap().catch((err) => logger.error(err));
