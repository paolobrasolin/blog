---
title: paolo.brasolin.github.io
options: footless
---

<h1 id="about">Hi.</h1>

I'm Paolo.
I do stuff.

I'd love you to drop me an email:
<a href="mailto:{{site.author.email}}">paolo.brasolin@gmail.com</a>.

Me, elsewhere:
<ul class="contact">
<li><a href="https://github.com/paolobrasolin/"
       class="github button">Github profile</a>
<li><a href="http://tex.stackexchange.com/users/82186/paolo-brasolin"
       class="tex-stackexchange button">TeX Stack Exchange profile</a>
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



