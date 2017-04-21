%% ----------------------------------------------------------------------------
%%
%% oauth2: Erlang OAuth 2.0 Client
%%
%% Copyright (c) 2012 KIVRA
%%
%% Permission is hereby granted, free of charge, to any person obtaining a
%% copy of this software and associated documentation files (the "Software"),
%% to deal in the Software without restriction, including without limitation
%% the rights to use, copy, modify, merge, publish, distribute, sublicense,
%% and/or sell copies of the Software, and to permit persons to whom the
%% Software is furnished to do so, subject to the following conditions:
%%
%% The above copyright notice and this permission notice shall be included in
%% all copies or substantial portions of the Software.
%%
%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
%% FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
%% DEALINGS IN THE SOFTWARE.
%%
%% ----------------------------------------------------------------------------

-module(oauth2c).

-export([
         retrieve_access_token/4
         ,retrieve_access_token/5
         ,retrieve_access_token/7
         ,retrieve_access_token/8
         ,request/3
         ,request/4
         ,request/5
         ,request/6
         ,request/7
         ,request/8
        ]).

-define(DEFAULT_ENCODING, json).

-record(client, {
        grant_type    = undefined :: binary() | undefined,
        auth_url      = undefined :: binary() | undefined,
        access_token  = undefined :: binary() | undefined,
        token_type    = undefined :: token_type() | undefined,
        refresh_token = undefined :: binary() | undefined,
        id            = undefined :: binary() | undefined,
        secret        = undefined :: binary() | undefined,
        scope         = undefined :: binary() | undefined,
        redirect_uri  = undefined :: binary() | undefined
}).

-type method()         :: head | get | put | post | trace | options | delete.
-type url()            :: binary().
-type at_type()        :: binary(). %% <<"password">> or <<"client_credentials">>
-type headers()        :: [header()].
-type header()         :: {binary(), binary()}.
-type status_codes()   :: [status_code()].
-type status_code()    :: integer().
-type reason()         :: term().
-type content_type()   :: json | xml | percent.
-type property()       :: atom() | tuple().
-type proplist()       :: [property()].
-type body()           :: proplist().
-type options()        :: [option()].
-type option()         :: {atom(), term()} | atom().
-type restc_response() :: {ok, Status::status_code(), Headers::headers(), Body::body()} |
                          {error, Status::status_code(), Headers::headers(), Body::body()} |
                          {error, Reason::reason()}.
-type response()       :: {restc_response(), #client{}}.
-type token_type()     :: bearer | unsupported.

%%% API ========================================================================


-spec retrieve_access_token(Type, URL, ID, Secret) ->
    {ok, Headers::headers(), #client{}} | {error, Reason :: binary()} when
    Type   :: at_type(),
    URL    :: url(),
    ID     :: binary(),
    Secret :: binary().
retrieve_access_token(Type, Url, ID, Secret) ->
    retrieve_access_token(Type, Url, ID, Secret, undefined, undefined, undefined).

-spec retrieve_access_token(Type, URL, ID, Secret, Scope) ->
    {ok, Headers::headers(), #client{}} | {error, Reason :: binary()} when
    Type   :: at_type(),
    URL    :: url(),
    ID     :: binary(),
    Secret :: binary(),
    Scope  :: binary() | undefined.
retrieve_access_token(Type, Url, ID, Secret, Scope) ->
    retrieve_access_token(Type, Url, ID, Secret, Scope, undefined, undefined).

-spec retrieve_access_token(Type, URL, ID, Secret, Scope, Code, RedirectUri) ->
    {ok, Headers::headers(), #client{}} | {error, Reason :: binary()} when
    Type        :: at_type(),
    URL         :: url(),
    ID          :: binary(),
    Secret      :: binary(),
    Scope       :: binary() | undefined,
    Code        :: binary() | undefined,
    RedirectUri :: binary() | undefined.
retrieve_access_token(Type, Url, ID, Secret, Scope, Code, RedirectUri) ->
    retrieve_access_token(Type, Url, ID, Secret, Scope, Code, RedirectUri, []).

-spec retrieve_access_token(Type, URL, ID, Secret, Scope, Code, RedirectUri, Options) ->
    {ok, Headers::headers(), #client{}} | {error, Reason :: binary()} when
    Type        :: at_type(),
    URL         :: url(),
    ID          :: binary(),
    Secret      :: binary(),
    Scope       :: binary() | undefined,
    Code        :: binary() | undefined,
    RedirectUri :: binary() | undefined,
    Options     :: options().
retrieve_access_token(Type, Url, ID, Secret, Scope, Code, RedirectUri, Options) ->
    Client = #client{
                     grant_type     = Type
                     ,auth_url      = Url
                     ,id            = ID
                     ,secret        = Secret
                     ,scope         = Scope
                     ,access_token  = Code
                     ,redirect_uri  = RedirectUri
                    },
    do_retrieve_access_token(Client, Options).

-spec request(Method, Url, Client) -> Response::response() when
    Method :: method(),
    Url    :: url(),
    Client :: #client{}.
request(Method, Url, Client) ->
    request(Method, ?DEFAULT_ENCODING, Url, [], [], [], Client).

-spec request(Method, Url, Expect, Client) -> Response::response() when
    Method :: method(),
    Url    :: url(),
    Expect :: status_codes(),
    Client :: #client{}.
request(Method, Url, Expect, Client) ->
    request(Method, ?DEFAULT_ENCODING, Url, Expect, [], [], Client).

-spec request(Method, Type, Url, Expect, Client) -> Response::response() when
    Method :: method(),
    Type   :: content_type(),
    Url    :: url(),
    Expect :: status_codes(),
    Client :: #client{}.
request(Method, Type, Url, Expect, Client) ->
    request(Method, Type, Url, Expect, [], [], Client).

-spec request(Method, Type, Url, Expect, Headers, Client) -> Response::response() when
    Method  :: method(),
    Type    :: content_type(),
    Url     :: url(),
    Expect  :: status_codes(),
    Headers :: headers(),
    Client  :: #client{}.
request(Method, Type, Url, Expect, Headers, Client) ->
    request(Method, Type, Url, Expect, Headers, [], Client).

-spec request(Method, Type, Url, Expect, Headers, Body, Client) -> Response::response() when
    Method  :: method(),
    Type    :: content_type(),
    Url     :: url(),
    Expect  :: status_codes(),
    Headers :: headers(),
    Body    :: body(),
    Client  :: #client{}.
request(Method, Type, Url, Expect, Headers, Body, Client) ->
    request(Method, Type, Url, Expect, Headers, Body, Client, []).

-spec request(Method, Type, Url, Expect, Headers, Body, Client, Options) -> Response::response() when
    Method  :: method(),
    Type    :: content_type(),
    Url     :: url(),
    Expect  :: status_codes(),
    Headers :: headers(),
    Body    :: body(),
    Client  :: #client{},
    Options :: options().
request(Method, Type, Url, Expect, Headers, Body, Client, Options) ->
    case do_request(Method, Type, Url, Expect, Headers, Body, Client, Options) of
        {{_, 401, _, _}, Client2} ->
            {ok, _RetrHeaders, Client3} = do_retrieve_access_token(Client2, Options),
            do_request(Method, Type, Url, Expect, Headers, Body, Client3, Options);
        Result -> Result
    end.


%%% INTERNAL ===================================================================


do_retrieve_access_token(#client{grant_type = <<"password">>} = Client, Options) ->
    Payload0 = [
                {<<"grant_type">>, Client#client.grant_type}
                ,{<<"username">>, Client#client.id}
                ,{<<"password">>, Client#client.secret}
               ],
    Payload = append_key(<<"scope">>, Client#client.scope, Payload0),
    case restc:request(post, percent, Client#client.auth_url, [200], [], Payload, Options) of
        {ok, _, Headers, Body} ->
            AccessToken = proplists:get_value(<<"access_token">>, Body),
            RefreshToken = proplists:get_value(<<"refresh_token">>, Body),
            Result = case RefreshToken of
                undefined ->
                    #client{
                            grant_type    = Client#client.grant_type
                            ,auth_url     = Client#client.auth_url
                            ,access_token = AccessToken
                            ,id           = Client#client.id
                            ,secret       = Client#client.secret
                            ,scope        = Client#client.scope
                            };
                _ ->
                    #client{
                            grant_type     = Client#client.grant_type
                            ,auth_url      = Client#client.auth_url
                            ,access_token  = AccessToken
                            ,refresh_token = RefreshToken
                            ,scope         = Client#client.scope
                            }
            end,
            {ok, Headers, Result};
        {error, _, _, Reason} ->
            {error, Reason};
        {error, Reason} ->
            {error, Reason}
    end;
do_retrieve_access_token(#client{grant_type = <<"client_credentials">>,
                                 id = Id, secret = Secret} = Client, Options) ->
    Payload0 = [{<<"grant_type">>, Client#client.grant_type}],
    Payload = append_key(<<"scope">>, Client#client.scope, Payload0),
    Auth = base64:encode(<<Id/binary, ":", Secret/binary>>),
    Header = [{<<"Authorization">>, <<"Basic ", Auth/binary>>}],
    case restc:request(post, percent, Client#client.auth_url,
                       [200], Header, Payload, Options) of
        {ok, _, Headers, Body} ->
            {AccessToken, _RefreshToken, TokenType } = extract_tokens(Body),
            Result = #client{
                             grant_type    = Client#client.grant_type
                             ,auth_url     = Client#client.auth_url
                             ,access_token = AccessToken
                             ,token_type   = get_token_type(TokenType)
                             ,id           = Client#client.id
                             ,secret       = Client#client.secret
                             ,scope        = Client#client.scope
                            },
            {ok, Headers, Result};
        {error, _, _, Reason} ->
            {error, Reason};
        {error, Reason} ->
            {error, Reason}
    end;
do_retrieve_access_token(#client{grant_type = <<"authorization_code">>,
                                 id = Id, secret = Secret} = Client, Options) ->
    Payload0 = [{<<"grant_type">>, Client#client.grant_type}],
    Payload = append_key(<<"redirect_uri">>, Client#client.redirect_uri, 
                append_key(<<"code">>, Client#client.access_token, 
                    append_key(<<"scope">>, Client#client.scope, 
                        Payload0
                        )
                    )
                ),
    Auth = base64:encode(<<Id/binary, ":", Secret/binary>>),
    Header = [{<<"Authorization">>, <<"Basic ", Auth/binary>>}
            , {<<"Accept">>, <<"application/json">>}],
    case restc:request(post, percent, Client#client.auth_url,
                       [200], Header, Payload, Options) of
        {ok, _, Headers, Body} ->
            {AccessToken, RefreshToken, TokenType } = extract_tokens(Body),
            Result = case RefreshToken of
                undefined ->
                    #client{
                            grant_type    = Client#client.grant_type
                            ,auth_url     = Client#client.auth_url
                            ,access_token = AccessToken
                            ,token_type   = get_token_type(TokenType)
                            ,id           = Client#client.id
                            ,secret       = Client#client.secret
                            ,scope        = Client#client.scope
                            };
                _ ->
                    #client{
                            grant_type     = Client#client.grant_type
                            ,auth_url      = Client#client.auth_url
                            ,access_token  = AccessToken
                            ,token_type   = get_token_type(TokenType)
                            ,refresh_token = RefreshToken
                            ,scope         = Client#client.scope
                            }
            end,
            {ok, Headers, Result};
        {error, _, _, Reason} ->
            {error, Reason};
        {error, Reason} ->
            {error, Reason}
    end.

-spec get_token_type(binary()) -> token_type().
get_token_type(Type) ->
    get_str_token_type(string:to_lower(binary_to_list(Type))).

-spec get_str_token_type(string()) -> token_type().
get_str_token_type("bearer") -> bearer;
get_str_token_type(_Else) -> unsupported.

do_request(Method, Type, Url, Expect, Headers, Body, Client, Options) ->
    Headers2 = add_auth_header(Headers, Client),
    {restc:request(Method, Type, Url, Expect, Headers2, Body, Options), Client}.

add_auth_header(Headers, #client{access_token = AccessToken, token_type = TokenType}) ->
    Prefix = autorization_prefix(TokenType),
    AH = {"Authorization", binary_to_list(<<Prefix/binary, " ", AccessToken/binary>>)},
    [AH | proplists:delete("Authorization", Headers)].

-spec autorization_prefix(token_type()) -> binary().
autorization_prefix(bearer) -> <<"Bearer">>;
autorization_prefix(unsupported) -> <<"token">>.

-spec append_key(binary(), binary() | undefined, proplist()) -> proplist().
append_key(_Key, undefined, Payload) -> Payload;
append_key(Key, Value, Payload) -> 
    [{Key, Value}|Payload].

-spec extract_tokens(binary() | proplist()) -> { binary(), binary() | undefined, binary()}.
extract_tokens(Body) when is_list(Body) -> 
    AccessToken = proplists:get_value(<<"access_token">>, Body),
    RefreshToken = proplists:get_value(<<"refresh_token">>, Body),
    TokenType = proplists:get_value(<<"token_type">>, Body, ""),
    {AccessToken, RefreshToken, TokenType };
extract_tokens(Body) -> 
    Body2 = mochiweb_util:parse_qs(Body),
    AccessToken = convert_to_binary(proplists:get_value("access_token", Body2)),
    RefreshToken = convert_to_binary(proplists:get_value("refresh_token", Body2, undefined)),
    TokenType = convert_to_binary(proplists:get_value("token_type", Body2, "")),
    {AccessToken, RefreshToken, TokenType }.

-spec convert_to_binary(string() | undefined) -> binary()  | undefined.
convert_to_binary(undefined) -> undefined;
convert_to_binary(A) -> list_to_binary(A).

