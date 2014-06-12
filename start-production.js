process.env.MONGOHQ_URL = 'mongodb://saron:qwerasdfzxcv@kahana.mongohq.com:10001/saron';
process.env.REDIS_HOST = 'pub-redis-11701.eu-west-1-1.2.ec2.garantiadata.com';
process.env.REDIS_PORT = 11701;
process.env.REDIS_PASSWORD = 'saron1234redis';

require('./server');