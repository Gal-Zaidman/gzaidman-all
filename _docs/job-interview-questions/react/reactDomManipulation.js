/*
Here we have a silmple render methed which renders and input element with date using
simple HTML and React render method. The render funtion is being called each second
what will be the difference in the two methods?

Hit:
- what will happen if a user tries to write something in the input field on each of the elemtnts?
*/
const render = () => {
    document.getElementById('mountNode').innerHTML = `
      <div>
        Hello HTML
        <input />
        <pre>${new Date().toLocaleTimeString()}</pre>
      </div>
    `;
  
    ReactDOM.render(
      React.createElement(
        'div',
        null,
        'Hello React',
        React.createElement('input', null),
        React.createElement('pre', null, new Date().toLocaleTimeString())
      ),
      document.getElementById('mountNode2')
    );
  };
  
  setInterval(render, 1000);