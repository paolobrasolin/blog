---
title: paolo.brasolin.github.io
options: footless
---

<h1 id="about">Hi.</h1>

I'm Paolo.

This is where I write things.

I'd love you to drop me an email:
<a href="mailto:{{site.author.email}}">paolo.brasolin@gmail.com</a>.

<ul class="contact">
<li><a href="https://github.com/paolobrasolin/"
       class="github button">Github</a>
<li><a href="https://www.linkedin.com/in/paolobrasolin"
       class="linkedin button">LinkedIn</a>
<li><a href="http://tex.stackexchange.com/users/82186/paolo-brasolin"
       class="tex-stackexchange button">TeX Stack Exchange</a>
</ul>

<h1 id="blog">Blog posts</h1>

<dl class="posts-list">
{% for post in site.posts %}
<dt><h3><a href="{{ post.url }}">{{ post.title }}</a></h3></dt>
<dd>
  <small><time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date_to_long_string }}</time>,
  {{ post.content | number_of_words }} words.</small><br>
  {{ post.excerpt | strip_html }} 
</dd>
{% endfor %}
</dl>



