Saron: Smart Web Monitor
==================

Monitoring application for Node.js using Derby.

Consists of two parts:

1. Main Saron server.
2. Client/daemon which you can install on many remote servers/PCs to monitor them.

Installation
==================

Install Saron main app:

     > git clone https://github.com/icaliman/saron.git
     > cd saron
     > npm install
     > node server.js

Open browser at [http://localhost:3000/login](http://localhost:3000/login) and register.

To start monitoring a server or PC, install Saron Daemon

    > git clone https://github.com/icaliman/saron-daemon.git
    > cd saron-daemon
    > npm install

Now you must configure Saron Daemon. Open `configuration.js` file and edit it:

```js
module.exports = {
  nodeName: "My Laptop", // a name for monitored server
  auth: {
    email: "your_email_here@gmail.com" // email whom you registered to Saron app
  },
  plugins: [ // plugins you want to use for this server
    "terminal", // you will have a terminal in browser connected to this server, useful for remote control
    "monitor",  // you will see in browser CPU, RAM and Hard Disk usage
    "logs"      // you will see in browser all logs from monitored log files
  ],
  logStreams: { // monitored log files, optional
    apache_stream_1: [
      "F:\\Programare\\Node.JS\\derby-0.6\\tests\\logs\\test_logs.txt"
    ],
    apache_stream_2: [
      "F:\\Programare\\Node.JS\\derby-0.6\\tests\\logs\\test_logs2.txt"
    ]
  },
  monitoredDrives: ['F', 'E', 'C'], // Disk drives you want to monitorize, on linux use '/'
  server: { // address to Saron server, you can use port and host or a full url
//    url: 'https://saron-monitor-c9-icaliman.c9.io',
    host: '127.0.0.1',
    port: 3000
  }
}
```

And finally start Saron Daemon:

    > node index.js

Open browser at [http://localhost:3000/admin](http://localhost:3000/admin) and enjoy.

## MIT License
Copyright (c) 2014 by Ion Caliman

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.