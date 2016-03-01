var loopback = require('loopback');
var path = require('path');
var moment = require('moment');
var app = loopback();
app.set('legacyExplorer', false);

app.dataSource('Memory', {
  connector: loopback.Memory,
  defaultForType: 'db'
});

var Widget = app.model('widget', {
  properties: {
    name: {
      type: String,
      required: true
    },
    updated: {
      type: Date,
      required: true
    }
  },
  dataSource: 'Memory'
});

var ds = app.dataSource('storage', {
  connector: require('loopback-component-storage'),
  provider: 'filesystem',
  root: path.join(__dirname, 'storage')
});

var container = loopback.createModel({ name: 'container', base: 'Model' });
app.model(container, { dataSource: 'storage' });

Widget.destroyAll(function () {
  Widget.create({
    name: 'FooBackend',
    updated: '2018-01-02T03:04:05.006Z'
  });
  Widget.create({
    name: 'BarBackend',
    updated: '2013-01-02T03:04:05.006Z'
  });
});

app.use(loopback.rest());
app.listen(3000, function() {
  console.log('http server is ready at https://localhost:3000.');
});
