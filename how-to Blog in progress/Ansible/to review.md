# Bla

- how to install ansible with RHEL subscription
- remember to addto $HOME/.vimrc file:
    autocmd FileType yaml setlocal ai ts=2 sw=2 et
- magic variables
- privilege escalation
- everything that is related to jinja2, jinja2 templates and syntax.
- Roles stracture.
- include/import static and dynamic.
- When creating a soft link we would probably need the "force" parameter.
- docs of the rhel system roles
- Modules
  - yum module:
      state
      name - can be a list of packages
  - firewalld module:
      service: Service to select
      state: allow or deny access
      permanent: *** need to remember to add permanent
      immediate: *** need to remember to add immediate
  - get_url module:
      url: the URL
      dest: where to save the content
      mode: permissions
  - uri module:
      status_code: A list of valid, numeric, HTTP status codes that signifies success of the request.
      url: HTTP or HTTPS URL in the form (http|https)://host.domain[:port]/path
      url_username: A username for the module to use for Digest, Basic or WSSE authentication.
      url_password: A password for the module to use for Digest, Basic or WSSE authentication.
      force_basic_auth: Force the sending of the Basic authentication header upon initial request.
      return_content: Whether or not to return the body of the response as a "content" key in the dictionary result.
      validate_certs: If `no', SSL certificates will not be validated.
  - service:
      name: Name of the service.
      state: 
          started/stopped are idempotent actions that will not run commands unless necessary.
          restarted will always bounce the service.
          reloaded will always reload.
      enabled: (bool) Whether the service should start on boot.

  - copy:
      content:
      When used instead of src, sets the contents of a file directly to the specified value.Works only when dest is a file. Creates the file if it does not exist.
      dest:
      owner:
      group:
      mode:

  - file:
      path: "{{ secrets_dir }}"
      dest: "{{ httpdconf_dest }}"
      recurse: yes
      state: directory
      group: apache
      mode: 0500

  - template:
  - lineinfile
  - blockinfile
  - stat
  - sefcontext
  - fetch



