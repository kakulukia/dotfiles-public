<template lang="pug">
body
  .pizza.is-hidden-mobile
    a(@click.prevent="showLightning = true")
      img(src="pizza.png")
      div
        span If you like it
        br
        span buy me a pizza :)

  // Modal für Lightning QR
  .lightning-modal-overlay(v-if="showLightning" @click.self="showLightning = false")
    .lightning-modal
      button.lightning-close(@click="showLightning = false" aria-label="Close") ×
      img.qr(src="tip_lightning_code.svg" alt="Lightning QR Code")
      h3 Oh, what kind of pizza is this? A lightning-fast one! ⚡️🍕
      p.
        This QR code is a Lightning address. Open your wallet, scan it, and send a few sats — like a tip,
        only faster than the oven preheats.
      p.
        Lightning is Bitcoin's turbo change: cheap, fast, and hassle-free.
      p.
        New to Lightning? A quick five-minute dive might be the most valuable use of your time today.
      p.
        Got ~44 minutes? #[a(href="https://www.youtube.com/watch?v=Pef22g53zsg", target="_blank") Here is a great introduction by Jack Mallers].

  .container
    .section
      h1.title.marginless zsh 4 humans
        a(
          href="https://github.com/kakulukia/dotfiles-public",
          title="Go to the GitHub-Repo"
        )
          img.github(src="github.png")
      a.claim(href="https://ohmyz.sh/", target="_blank") Your terminal never felt #[i this] good before.™
    .section
      asciinema-player#player.is-hidden-mobile(
        v-pre,
        src="demo.cast",
        poster="npt:0:01",
        speed="1.5",
        idle-time-limit="1"
      )
      iframe.is-hidden-tablet(
        width="560",
        height="315",
        src="https://www.youtube.com/embed/nkT3tQFLddU?VQ=HD720",
        frameborder="0",
        allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture",
        allowfullscreen
      )

      h2.subtitle Intro
      p.
        For the last several years (initial commit 2014-10-04) I have been building up my shell environment and it's the
        first thing that gets installed on a new #[del server or] Mac. Especially the reverse
        history search is a huge time saver.
      p.
        It's been a long journey from default bash to bash-it, oh-my-bash, then oh-my-zsh, to prezto, and…
      p
        strong z4h
      p.
        …and now, apart from some tool that gets added
        every now and then — I finally feel like it can't get any better. 😎
      p.
        Some of the stuff in this repo I didn't even know was possible before I switched to ZSH or
        discovered app X. So I just wanted to share the whole collection. I did a few improvements myself,
        but basically it was all out there. This repo enables everybody to get all the goodies at
        once and helps me feel at home whenever I open a new shell.

      h2.subtitle Installation
      p.
        Yes, the installation process is a bit more tricky than the last version, BUT this only needs to be done #[strong 1] time.
        Z4h will #[a(href="https://asciinema.org/a/542763") teleport] your shell to whichever system you are logging in to. So over there you only may need to install some tools. That's it!

      p
        br
        strong Preparing your environment:

      ol
        li Fork this dotfiles-public repo (change #[code .gitconfig] to match your username and email)
        li Create a dotfile-private repo and let GitHub create a ReadMe to have some content to download
        li Copy your private key to the new machine or create a new one and add it to GitHub
        li Make sure this key is loaded by ssh if its name differs from id_rsa
        li Make sure #[strong git, zsh, python, curl] and the #[strong build-essential package] (for installing extra tools) is installed
        li Use the following command to bootstrap your Mac (only tested on macOS so far; should also work on Linux though)
        li Make sure to change #[code GITHUB_USERNAME] to your GitHub username

      br
      blockquote.
        GITHUB_USERNAME=kakulukia bash -c 'curl -fsSL "https://raw.githubusercontent.com/$GITHUB_USERNAME/dotfiles-public/main/bin/bootstrap-machine.sh" | bash'


      br
      p
        strong This will do the following:

      ul
        li It downloads the previously created public and private repos directly to your home folder and adds .dotfiles-public/.dotfiles-private as the git dirs for those repos
        li The next time you start your terminal it will automatically install z4h
        li You can cycle between public, private and no repo with Ctrl+P
          figure
              img(src="switch_repos.png" title="switching repos")
              figcaption cycle between the repos with Ctrl+P
      p Now you are free to add any file under #[code $HOME] to your public or private settings and keep them.

      p In the misc folder you can find:
      ul
        li The Powerline patched SourceCode font (you may use any #[a(href="https://www.nerdfonts.com/" target="_blank") Nerdfont])
        li better-osx-settings script
        li.
          An opinionated set of #[a(href="https://github.com/kakulukia/dotfiles-public/blob/main/bin/apps.json") tools] that can be
          installed via #[span.command select-tools]

      p Your settings (public and private) can be updated via #[span.command sync-dotfiles]

      h2.subtitle Features
      p Apart from what's shown in the recording, here is some more of what's included:
      ul
        li suggestions (grey text) - use the right arrow key to accept
        li navigate with Shift+Arrow keys
          ul
            li Shift+up → dir up
            li Shift+down → search any visited path and jump there
            li Shift+Left/Right → cycle through your persistent path history
        li
          span.
            history reverse search - use the up arrow to cycle through previous commands.
            Anything you typed before hitting the up key will be used as a filter and be highlighted.
            This seriously saves a lot of typing. 😇
          br
          br
          figure
            img(src="reverse_search.png" title="context sensitive history search")
            figcaption mm + up arrow
          p.
            #[strong Pro tip:] add #[code # whatever tag] to your command. Next time when you decide to run it, type your tag or a part of it, press up and enter. This is how you can "tag" commands and easily find them later. You can apply more than one "tag". Technically, everything after # is a comment. (thx romkatv!)

        li red / green colored commands - shows that the command is (un)available
        li . is in the path so no need for any ./ prefixing executables
        li path
          ul
            li print a sorted version of $PATH
            li add the given folder to $PATH and
            li append the given path to your .zsh-profile when called with #[span.command path --save DIR]
        li mv with one argument - no need to type the file name twice for renaming
        li ,, - jump to the git root dir
        li o - will open the finder in the current directory
        li
          a(href="https://github.com/kakulukia/dotfiles-public/tree/main/bin") cdto.app
          |  - there is an app in the bin folder that provides a
          | way to reverse the above trick and opens a terminal at the current Finder location.
          | Use the Command key to just drag it into the Finder's toolbar.
          br
          br
          figure
            img(src="cdto.png" title="cdto in the finder")
            figcaption The result will look like this
        li Just for self-reference the app next to cdto is #[a(href="https://github.com/Ji4n1ng/OpenInTerminal") OpenInTerminal]

        li
          a(
            href="https://github.com/chamburr/glance"
          ) QuickLook Plugins
          span  for macOS
        li diff - aliased to diff-so-fancy in general, not just the git version
        li ips - will show all local ips (IPV4) / ip[4|6] will show some info about your external one
        li ping - is aliased to prettyping
        li rg - alias for "rg -S --max-columns 444" won't clutter the screen with nasty one line files
        li I love the global alias G for "| rg" — I use that a lot
        li A customized starship.toml for a minimal prompt
        li up - that's the live preview pipe thing you saw at the end of the screencast. It's activated with CTRL+P for pipe.
        li The rest can be found in the #[a(href="https://github.com/kakulukia/dotfiles-public/tree/main/.alias") .alias] config
        li For everyone who forgets a leading sudo from time to time - you can now answer that error with a simple #[span.command please] (just do it) :)
        li #[a(href="https://github.com/LazyVim/LazyVim") LazyVim] is making editing in the terminal a pleasure
        li And finally the startup speed is very good:
          figure
            img(src="benchmark.png" title="startup benchmark")
            figcaption current startup speed with all features enabled

      h2.subtitle ToDo
      ul
        li This list is finally empty :)

      h2.subtitle Credits
      p
        | This theme was inspired by
        a(
          href="https://github.com/Bash-it/bash-it/blob/master/themes/powerline-plain/powerline-plain.theme.bash" target="_blank"
        )  PowerlinePlain
        |  and based on
        a(href="https://github.com/caiogondim/bullet-train-oh-my-zsh-theme" target="_blank")  BulletTrain
        | .
        br
        p The awesome z4h by #[a(href="https://github.com/romkatv/zsh4humans") romkatv].
        strong Generally:
        |  Mad props to all awesome devs who build most of the apps referenced here.
        | Too many to list em all, but most if not all do feature a credit line inside the scripts or a reference to their repos.
</template>

<script>
export default {
  data() {
    return {
      showLightning: false
    }
  },
  mounted() {
    let asciinema = document.createElement("script");
    asciinema.setAttribute("src", "asciinema-player.js");
    document.head.appendChild(asciinema);
    window.addEventListener('keydown', this.onKeydown)
  },
  beforeUnmount() {
    window.removeEventListener('keydown', this.onKeydown)
  },
  methods: {
    onKeydown (e) {
      if (e.key === 'Escape') this.showLightning = false
    }
  }
};
</script>

<style lang="sass">
@font-face
  font-family: SauceCodePro
  src: url(assets/SauceCodePro.ttf)

a
  color: #8a56df
  &:hover
    color: #8a56df
    text-decoration: underline

code
  color: black

blockquote
  border-left: 4px solid #6a737d
  margin-left: 0
  margin-right: 0
  padding: 1em
  color: black
  background-color: #f6f8fa

body::-webkit-scrollbar
  width: 10px
body::-webkit-scrollbar-thumb
  background-image: url(../public/scrollbar.png)
html
  scrollbar-width: thin             /* thin | auto | none */
  scrollbar-color: #6a737d transparent /* thumb color, track color */

iframe
  width: 100%
  display: block

body, .asciinema-terminal
  font-family: "SauceCodePro", serif

h1.title.marginless
  margin-bottom: 0
.claim
  color: #4a4a4a
  i
    font-weight: bold
    /*color: #c5d928*/

.section + .section
  padding-top: 0
img.github
  height: 30px
  margin-left: 10px
  position: relative
  top: 4px
.pizza
  height:
  z-index: 1
  position: absolute
  top: 20px
  right: -185px
  a
    display: flex
    align-items: center
    color: #cd4d4c
    img
      height: 50px
    div
      margin: 0 20px 0 25px
      transition: ease-in-out 0.2s
  &:hover
    right: 0

figure
  display: block
  margin: 1em auto
  text-align: center
  figcaption
    font-size: 0.7em

span.command
  background: #eee
  font-style: italic
  padding: 0 5px

ol
  padding-left: 2em

ul
  margin-bottom: 1em
  li:before
    content: "> "
    font-weight: bold
    margin-left: -20px
  li
    padding-left: 30px

    ul
      margin-left: 1em
      margin-top: 0.5em
      li:before
        content: "• "
        margin-left: -20px

p
  margin-bottom: 0.5em

h1, h2, h3
  border-bottom: 1px solid #eaecef
h2, h3
  margin-top: 2em

.asciinema-player .control-bar, .asciinema-theme-asciinema .asciinema-terminal
  background: #282a36
  border-color: #282a36

.asciinema-theme-asciinema
  .fg-1
    color: #AB6053
  .fg-2
    color: #70865B
  .fg-4
    color: #5E70A4
  .fg-6
    color: #A99367
  .fg-8
    color: #9c9c9c
  .fg-9
    color: #AB2C1D
  .fg-10
    color: #44973C
  .bg-52
    background: #571106
  .bg-22
    background: #275D17
  .fg-146
    color: #AFB0D4
  .bg-1
    background: #AB6052
  .fg-12
    color: #90ACF3
  .bg-2
    background: #70875B
  .bg-3
    background: #A67542
  .bg-4
    background: #5D70A5

@media (max-width: 821px)
  .install p
    font-size: 13px
@media (min-width: 822px) and (max-width: 1020px)
  .install p
    font-size: 14px

.asciinema-player .start-prompt .play-button div span
  display: flex
  align-items: center
  margin: 0 auto
  justify-content: center

// Styles für Lightning-Modal
.lightning-modal-overlay
  position: fixed
  inset: 0
  background: rgba(0,0,0,0.6)
  display: flex
  align-items: center
  justify-content: center
  z-index: 9999

.lightning-modal
  background: #fff
  color: #333
  border-radius: 10px
  box-shadow: 0 10px 30px rgba(0,0,0,0.3)
  width: 80vw
  max-height: 90vh
  overflow: auto
  padding: 22px 22px 18px
  position: relative

.lightning-close
  appearance: none
  background: transparent
  border: 0
  font-size: 24px
  line-height: 1
  cursor: pointer
  position: absolute
  top: 8px
  right: 10px

img.qr
  display: block
  height: 210px
  max-width: 70vw
  margin: 10px auto 18px
</style>
