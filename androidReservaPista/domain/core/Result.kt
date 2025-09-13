package com.jonathandevapps.reservapistagilena.domain.core

sealed class Result<out T> {
    data class Success<out T>(val data: T) : Result<T>()
    data class Error(val error: DomainError) : Result<Nothing>()
    
    val isSuccess: Boolean
        get() = this is Success
        
    val isError: Boolean
        get() = this is Error
        
    fun getOrNull(): T? = when (this) {
        is Success -> data
        is Error -> null
    }
    
    fun getOrThrow(): T = when (this) {
        is Success -> data
        is Error -> throw error
    }
    
    inline fun onSuccess(action: (T) -> Unit): Result<T> {
        if (this is Success) action(data)
        return this
    }
    
    inline fun onError(action: (DomainError) -> Unit): Result<T> {
        if (this is Error) action(error)
        return this
    }
    
    inline fun <R> map(transform: (T) -> R): Result<R> = when (this) {
        is Success -> Success(transform(data))
        is Error -> this
    }
    
    inline fun <R> flatMap(transform: (T) -> Result<R>): Result<R> = when (this) {
        is Success -> transform(data)
        is Error -> this
    }
    
    companion object {
        fun <T> success(data: T): Result<T> = Success(data)
        fun <T> error(error: DomainError): Result<T> = Error(error)
        fun <T> error(message: String, cause: Throwable? = null): Result<T> = 
            Error(DomainError.UnknownError(cause))
    }
} 