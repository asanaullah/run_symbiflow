
// DO NOT EDIT THIS FILE - it is machine generated -*- c++ -*-

#ifndef __gnu_java_beans_DummyAppletContext__
#define __gnu_java_beans_DummyAppletContext__

#pragma interface

#include <java/lang/Object.h>
extern "Java"
{
  namespace gnu
  {
    namespace java
    {
      namespace beans
      {
          class DummyAppletContext;
      }
    }
  }
  namespace java
  {
    namespace applet
    {
        class Applet;
        class AudioClip;
    }
    namespace awt
    {
        class Image;
    }
    namespace net
    {
        class URL;
    }
  }
}

class gnu::java::beans::DummyAppletContext : public ::java::lang::Object
{

public: // actually package-private
  DummyAppletContext();
public:
  virtual ::java::applet::AudioClip * getAudioClip(::java::net::URL *);
  virtual ::java::awt::Image * getImage(::java::net::URL *);
  virtual ::java::applet::Applet * getApplet(::java::lang::String *);
  virtual ::java::util::Enumeration * getApplets();
  virtual void showDocument(::java::net::URL *);
  virtual void showDocument(::java::net::URL *, ::java::lang::String *);
  virtual void showStatus(::java::lang::String *);
  virtual void setStream(::java::lang::String *, ::java::io::InputStream *);
  virtual ::java::io::InputStream * getStream(::java::lang::String *);
  virtual ::java::util::Iterator * getStreamKeys();
private:
  static ::java::util::Enumeration * EMPTY_ENUMERATION;
public:
  static ::java::lang::Class class$;
};

#endif // __gnu_java_beans_DummyAppletContext__
