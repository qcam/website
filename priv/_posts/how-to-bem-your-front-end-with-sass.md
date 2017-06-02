{
  "title": "How to BEM your front-end code with sass",
  "slug": "how-to-bem-your-front-end-with-sass",
  "date": "2014-08-02",
  "keywords": ["bem", "sass", "css"],
  "tags": ["bem", "sass", "css"],
  "description": "I became a fan of BEM two months ago and this is how I BEM my code with Sass"
}
---
I tried to refactor my CSS about two months ago when I started to realize that my CSS became unmaintainable, slow and messy.
---
I tried to refactor my CSS about two months ago when I started to realize that my CSS became unmaintainable, slow and messy.

This is what my markup looks like

```html
<div class='products'>
  <div class='product'>
    <div class='left'>
      <img class='photo' src='url/to/photo.jpg'/>
      <div class='description'>
        <p>Just a short description...</p>
      </div>
      <div class='price'>$100.00</div>
    </div>
    <div class='right'>
      <div class='buttons-group'>
        <a class='wishlist' href='url/to/wishlist'>Add to my wishlist</a>
        <a class='buy' href='url/to/wishlist'>Add to cart</a>
      </div>
    </div>
  </div>
</div>
```

And my SCSS

```scss
.products {
  .product {
    .left {
      .photo {
        /* photo style here */
      }

      .description {
        /* description style here */
      }

      .price {
        /* price */
      }
    }

    .right {
      .button-group {
        .wishlist {
          /* wishlist style here */
        }

        .buy {
          /* buy style here */
        }
      }
    }
  }
}
```

### Dig a bit deeper

**What does the generated CSS look like?**

```css

.products .product .left .photo {}
.products .product .left .description {}
/* or */
.products .product .right .buttons-group .wishlist .or_deeper {}
```

Apparently, it is not good.

**What is wrong with it?**

First of all, I would say that it is a **bad** idea to nest your CSS selectors. 
Unnecessary nesting will only increase the specificity of our css and make it unreusable.

One of the biggest confusions of mine(or ours?) about CSS is to mistakenly assume that browsers read css left-to-right. 
For selector like `.products .product a` we always thought that browsers were looking for `.products` and then `.product` and applying styles to all the inside `a` tags.
But actually, browsers read right-to-left. It means that browsers see an `a` in a `.product` class of a `.products` class.

Harry Roberts wrote a very cool series about [the selectors](http://csswizardry.com/2012/05/keep-your-css-selectors-short/).

### BEM it FTW!!!

[BEM](http://bem.info/method/definitions) stands for Blocks, Elements and Modifiers, is a front-end programming methodology and developed by [Yandex](http://www.yandex.com/).

> One of the most common examples of a methodology in programming is Object-Oriented Programming. It's a programming paradigm embodied by many languages. In some ways, BEM is similar to OOP. It's a way of describing reality in code, a range of patterns, and a way of thinking about program entities regardless of programming languages being used.

According to the definition of BEM, our structure will be:

- Product is our Block.
- Photo, Button are the Elements
- Wishlist, Buy are the modifiers of our Button

```html
<div class='products'>
  <div class='product'>
    <div class='product__left'>
      <div class='product__photo'></div>
    </div>
    <div class='product__right'>
      <div class='product__button-group'>
        <a class='product__button product__button--wishlist'>Add to Wishlist</a>
        <a class='product__button product__button--buy'>Add to cart</a>
      </div>
    </div>
  </div>
</div>
```

And our CSS would be

```scss
.products {}
.product {}
.product__left {}
.product__photo {}
.product__button-group {}
.product__button {}
.product__button--wishlist {}
.product__button--buy {}
```

### How to apply to my SASS?

The idea of BEM is really great to me and I wanted to implement it in my refacoring.
But as a spoiled Rails programmer, it is just like going back to the Stone Age with the pure CSS syntax.

Luckily, [the sass `@content` and `@at-root` directives saved my life.](http://robots.thoughtbot.com/sasss-content-directive) 

I added `element` and `modifier` mixins to my `mixins.scss`

```scss
@mixin element($name) {
  @at-root &__#{$name} {
    @content;
  }
}

@mixin modifier($name) {
  @at-root &--#{$name} {
    @content;
  }
}
```

Now I can write somethings cool like this.

```scss
.product {
  @include element(left) {
    /* content here */
  }

  @include element(photo) {
    /* content here */
  }

  @include element(button) {
    @include modifier(wishlist) {
      /* content here */
    }

    @include modifier(buy) {
      /* content here */
    }
  }
}
```

### In conclusion

So that's how I got my html classes and css BEMed and refactored! Fortunately, it is still working perfectly so far.

BEM really makes my front-end code clearer, single responsibility, easier to read, understand and extend. 

So, what are you waiting for? Go and BEM it!!!
